import React, { useState, useEffect } from 'react';
import MessageService from '../Services/MessageService';

const ChatModal = ({ orderId, recipientUsername, onClose }) => {
  const [messages, setMessages] = useState([]);
  const [newMessage, setNewMessage] = useState('');

  // Функция для получения сообщений
  const fetchMessages = async () => {
    try {
      const response = await MessageService.getMessagesForOrder(orderId);
      setMessages(response.data);
    } catch (error) {
      console.error('Failed to load messages', error);
    }
  };

  // Периодическое обновление сообщений
  useEffect(() => {
    fetchMessages();
    const interval = setInterval(fetchMessages, 3000); // Обновляем каждые 3 секунды
    return () => clearInterval(interval); // Очищаем интервал при размонтировании
  }, [orderId]);

  // Отправка нового сообщения
  const handleSendMessage = async () => {
    try {
      await MessageService.sendMessage({
        orderId,
        recipientUsername,
        content: newMessage,
      });
      setNewMessage('');
      fetchMessages(); // Обновляем сообщения после отправки
    } catch (error) {
      console.error('Failed to send message', error);
    }
  };

  return (
    <div className="modal show d-block">
      <div className="modal-dialog">
        <div className="modal-content">
          <div className="modal-header">
            <h5 className="modal-title">Chat</h5>
            <button className="btn-close" onClick={onClose}></button>
          </div>
          <div className="modal-body">
            <ul>
              {messages.map((msg, index) => (
                <li key={index}>
                  <strong>{msg.senderUsername}:</strong> {msg.content}
                </li>
              ))}
            </ul>
            <textarea
              className="form-control"
              value={newMessage}
              onChange={(e) => setNewMessage(e.target.value)}
              placeholder="Type your message..."
            />
          </div>
          <div className="modal-footer">
            <button className="btn btn-primary" onClick={handleSendMessage}>
              Send
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ChatModal;