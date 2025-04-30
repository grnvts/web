import React, { useEffect, useState, useRef } from 'react';
import { GoogleMap, LoadScript, Marker, DirectionsRenderer } from '@react-google-maps/api';
import GoogleMapsService from '../../Services/GoogleMapsService';
import './HomePage.css';

const libraries = ['places'];

const HomePage = () => {
  const [mapCenter, setMapCenter] = useState({
    lat: 53.9300177,
    lng: 27.5869516
  });
  const [nearbyPlaces, setNearbyPlaces] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [directions, setDirections] = useState(null);
  const [streetViewUrl, setStreetViewUrl] = useState(null);
  const [searchInput, setSearchInput] = useState('');
  const [suggestions, setSuggestions] = useState([]);
  const [isMapLoaded, setIsMapLoaded] = useState(false);
  
  const mapRef = useRef(null);
  const searchTimeout = useRef(null);

  const companyStats = {
    yearFounded: '2018',
    completedProjects: '500+',
    permits: '5',
    satisfiedClients: '100%'
  };

  const mapContainerStyle = {
    width: '100%',
    height: '400px'
  };

  const onMapLoad = (map) => {
    mapRef.current = map;
    setIsMapLoaded(true);
  };

  useEffect(() => {
    const fetchLocationData = async () => {
      if (!isMapLoaded) return;
      
      try {
        setLoading(true);
        setError(null);

        const coordinates = await GoogleMapsService.getCoordinates('ул. Леонида Беды 4/1, Минск, Беларусь');
        setMapCenter(coordinates);

        const places = await GoogleMapsService.searchNearbyPlaces(coordinates);
        setNearbyPlaces(places);

        setStreetViewUrl(GoogleMapsService.getStreetViewUrl(coordinates));
      } catch (err) {
        console.error('Ошибка загрузки данных о местоположении:', err);
        setError(err.message || 'Не удалось загрузить данные о местоположении');
      } finally {
        setLoading(false);
      }
    };

    fetchLocationData();
  }, [isMapLoaded]);

  const handleSearchChange = (e) => {
    const value = e.target.value;
    setSearchInput(value);
    setSuggestions([]);
    setError(null);

    if (searchTimeout.current) {
      clearTimeout(searchTimeout.current);
    }

    if (!value.trim() || !isMapLoaded) {
      return;
    }

    searchTimeout.current = setTimeout(async () => {
      try {
        const predictions = await GoogleMapsService.getAutocompleteSuggestions(value);
        setSuggestions(predictions);
      } catch (err) {
        console.error('Ошибка получения подсказок:', err);
        setError(err.message || 'Не удалось получить подсказки адресов');
      }
    }, 300);
  };

  const handleSuggestionClick = async (suggestion) => {
    try {
      setSearchInput(suggestion.description);
      setSuggestions([]);
      setError(null);
      setLoading(true);
      
      const result = await GoogleMapsService.getDirections(
        'ул. Леонида Беды 4/1, Минск, Беларусь',
        suggestion.description
      );
      
      setDirections(result.directions);
      
      if (mapRef.current && result.directions.routes[0]) {
        const bounds = new window.google.maps.LatLngBounds();
        result.directions.routes[0].legs[0].steps.forEach((step) => {
          bounds.extend(step.start_location);
          bounds.extend(step.end_location);
        });
        mapRef.current.fitBounds(bounds);
      }
    } catch (err) {
      console.error('Ошибка построения маршрута:', err);
      setError(err.message || 'Не удалось построить маршрут');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="home-page">
      <header className="hero-section">
        <div className="background-image">
          <img src="https://avatars.mds.yandex.net/get-altay/5503221/2a0000017da37cc53ab63628662daecb5937/XXL_height" alt="Фон" />
        </div>
        <div className="hero-content">
          <h1>РЕМОНТ-МАСТЕР</h1>
          <p>Профессиональный ремонт жилых и коммерческих помещений</p>
          <button className="cta-button">Заказать ремонт</button>
        </div>
      </header>

      <section className="stats-section">
        <div className="stats-container">
          <div className="stat-item">
            <h2>{companyStats.yearFounded}</h2>
            <p>год основания</p>
          </div>
          <div className="stat-item">
            <h2>{companyStats.completedProjects}</h2>
            <p>выполненных проектов</p>
          </div>
          <div className="stat-item">
            <h2>{companyStats.permits}</h2>
            <p>профессиональных лицензий</p>
          </div>
          <div className="stat-item">
            <h2>{companyStats.satisfiedClients}</h2>
            <p>довольных клиентов</p>
          </div>
        </div>
      </section>

      <section className="about-section">
        <h2>О НАС</h2>
        <div className="about-content">
          <div className="about-text">
            <p>Мы создаем уютные пространства для жизни и работы, 
               как если бы делали ремонт для себя. Каждый проект для нас — 
               это возможность превзойти ожидания клиента и создать 
               пространство вашей мечты.</p>
          </div>
        </div>
      </section>

      <section className="services-section">
        <h2>НАШИ УСЛУГИ</h2>
        <div className="services-grid">
          <div className="service-card">
            <h3>Мелкий бытовой ремонт</h3>
            <p>Замена розеток, смесителей, установка карнизов и полок, ремонт мебели</p>
          </div>
          <div className="service-card">
            <h3>Сантехнические работы</h3>
            <p>Установка и ремонт сантехники, устранение протечек, замена труб</p>
          </div>
          <div className="service-card">
            <h3>Электромонтажные работы</h3>
            <p>Замена проводки, установка светильников, диагностика электросети</p>
          </div>
          <div className="service-card">
            <h3>Отделочные работы</h3>
            <p>Поклейка обоев, покраска, укладка плитки, установка дверей</p>
          </div>
        </div>
      </section>

      <section className="location-section">
        <h2>ГДЕ МЫ НАХОДИМСЯ</h2>
        <div className="location-content">
          <div className="address-info">
            <h3>Наш офис</h3>
            <p>г. Минск, ул. Л.Беды, д. 4/1</p>
            <p>Телефон: +375 (29) 123-45-67</p>
            <p>Email: info@remont-master.ru</p>
            <p>Режим работы: Пн-Пт с 9:00 до 18:00</p>
            
            <div className="search-container">
              <input
                type="text"
                value={searchInput}
                onChange={handleSearchChange}
                placeholder="Введите адрес для построения маршрута"
                className="search-input"
                disabled={!isMapLoaded}
              />
              {suggestions.length > 0 && (
                <ul className="suggestions-list">
                  {suggestions.map((suggestion, index) => (
                    <li
                      key={index}
                      onClick={() => handleSuggestionClick(suggestion)}
                      className="suggestion-item"
                    >
                      {suggestion.description}
                    </li>
                  ))}
                </ul>
              )}
            </div>

            {loading && <div className="loading-message">Загрузка...</div>}
            
            {error && (
              <div className="error-message">
                {error}
              </div>
            )}

            {directions && !error && (
              <div className="route-info">
                <h4>Информация о маршруте:</h4>
                <p>Расстояние: {directions.routes[0].legs[0].distance.text}</p>
                <p>Время в пути: {directions.routes[0].legs[0].duration.text}</p>
              </div>
            )}
          </div>
          
          <div className="map-container">
            <LoadScript 
              googleMapsApiKey={process.env.REACT_APP_GOOGLE_MAPS_API_KEY} 
              libraries={libraries}
            >
              <GoogleMap
                mapContainerStyle={mapContainerStyle}
                center={mapCenter}
                zoom={16}
                onLoad={onMapLoad}
              >
                <Marker position={mapCenter} />
                {nearbyPlaces.map((place, index) => (
                  <Marker
                    key={index}
                    position={{
                      lat: place.geometry.location.lat(),
                      lng: place.geometry.location.lng()
                    }}
                  />
                ))}
                {directions && <DirectionsRenderer directions={directions} />}
              </GoogleMap>
            </LoadScript>
          </div>

          {streetViewUrl && (
            <div className="street-view-container">
              <h3>Панорама улицы</h3>
              <img src={streetViewUrl} alt="Панорама улицы" className="street-view-image" />
            </div>
          )}
        </div>
      </section>
    </div>
  );
};

export default HomePage; 