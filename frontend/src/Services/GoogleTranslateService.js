import axios from 'axios';

const API_KEY = 'AIzaSyAGZtmr6QmG5ya-Qm80ZtMM9i0aEwQrUG4';
const ENDPOINT = 'https://translation.googleapis.com/language/translate/v2';

export const translateText = async (text, targetLang = 'en') => {
  const response = await axios.post(`${ENDPOINT}?key=${API_KEY}`, {
    q: text,
    target: targetLang,
  });
  return response.data.data.translations[0].translatedText;
};