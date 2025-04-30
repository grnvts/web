import axios from 'axios';

const GOOGLE_MAPS_API_KEY = process.env.REACT_APP_GOOGLE_MAPS_API_KEY;
const GEOCODING_BASE_URL = 'https://maps.googleapis.com/maps/api/geocode/json';
const DIRECTIONS_BASE_URL = 'https://maps.googleapis.com/maps/api/directions/json';
const DISTANCE_MATRIX_URL = 'https://maps.googleapis.com/maps/api/distancematrix/json';

class GoogleMapsService {
    static async waitForGoogleMaps() {
        let attempts = 0;
        const maxAttempts = 20;
        
        while (!window.google?.maps && attempts < maxAttempts) {
            await new Promise(resolve => setTimeout(resolve, 100));
            attempts++;
        }
        
        if (!window.google?.maps) {
            throw new Error('Google Maps API не загрузился');
        }
    }

    static async getCoordinates(address) {
        await this.waitForGoogleMaps();
        const geocoder = new window.google.maps.Geocoder();
        
        return new Promise((resolve, reject) => {
            geocoder.geocode({ 
                address: address,
                region: 'BY'
            }, (results, status) => {
                if (status === 'OK' && results && results.length > 0) {
                    const location = results[0].geometry.location;
                    resolve({
                        lat: location.lat(),
                        lng: location.lng(),
                        formattedAddress: results[0].formatted_address
                    });
                } else {
                    reject(new Error(`Не удалось найти адрес: ${address}`));
                }
            });
        });
    }

    static async getPlaceDetails(placeId) {
        try {
            const response = await axios.get(`https://maps.googleapis.com/maps/api/place/details/json`, {
                params: {
                    place_id: placeId,
                    key: GOOGLE_MAPS_API_KEY
                }
            });

            if (response.data.result) {
                return response.data.result;
            }
            throw new Error('No place details found');
        } catch (error) {
            console.error('Error getting place details:', error);
            throw error;
        }
    }

    static async searchNearbyPlaces(location, radius = 1000) {
        await this.waitForGoogleMaps();
        
        // Создаем временный div для PlacesService
        const mapDiv = document.createElement('div');
        const map = new window.google.maps.Map(mapDiv, {
            center: location,
            zoom: 15
        });
        
        const service = new window.google.maps.places.PlacesService(map);
        
        return new Promise((resolve, reject) => {
            service.nearbySearch({
                location: location,
                radius: radius,
                type: ['store', 'business']
            }, (results, status) => {
                if (status === 'OK') {
                    resolve(results);
                } else {
                    reject(new Error('Не удалось найти места поблизости'));
                }
            });
        });
    }

    static async getDirections(origin, destination) {
        await this.waitForGoogleMaps();
        const directionsService = new window.google.maps.DirectionsService();
        
        return new Promise((resolve, reject) => {
            directionsService.route({
                origin: origin,
                destination: destination,
                travelMode: window.google.maps.TravelMode.DRIVING,
                region: 'BY'
            }, (result, status) => {
                if (status === 'OK' && result) {
                    resolve({
                        directions: result,
                        distance: result.routes[0].legs[0].distance,
                        duration: result.routes[0].legs[0].duration
                    });
                } else {
                    reject(new Error(`Не удалось построить маршрут: ${status}`));
                }
            });
        });
    }

    static async getDistanceMatrix(origins, destinations, mode = 'driving') {
        try {
            const response = await axios.get(DISTANCE_MATRIX_URL, {
                params: {
                    origins: origins.join('|'),
                    destinations: destinations.join('|'),
                    mode: mode,
                    key: GOOGLE_MAPS_API_KEY
                }
            });

            if (response.data.rows) {
                return response.data.rows;
            }
            throw new Error('No distance matrix found');
        } catch (error) {
            console.error('Error getting distance matrix:', error);
            throw error;
        }
    }

    static async getAutocompleteSuggestions(input) {
        await this.waitForGoogleMaps();
        const autocompleteService = new window.google.maps.places.AutocompleteService();
        
        return new Promise((resolve, reject) => {
            autocompleteService.getPlacePredictions({
                input: input,
                componentRestrictions: { country: 'BY' },
                types: ['address'],
                language: 'ru',
                region: 'BY'
            }, (predictions, status) => {
                if (status === 'OK' && predictions) {
                    resolve(predictions);
                } else {
                    reject(new Error('Не удалось получить подсказки'));
                }
            });
        });
    }

    static getStreetViewUrl(location) {
        if (!process.env.REACT_APP_GOOGLE_MAPS_API_KEY) {
            throw new Error('API ключ не настроен');
        }
        return `https://maps.googleapis.com/maps/api/streetview?size=600x300&location=${location.lat},${location.lng}&key=${process.env.REACT_APP_GOOGLE_MAPS_API_KEY}`;
    }
}

export default GoogleMapsService; 