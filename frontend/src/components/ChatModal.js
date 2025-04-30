import React, { useState, useEffect, useRef } from 'react';
import MessageService from '../Services/MessageService';
import { useSelector } from 'react-redux';
import { useTranslation } from 'react-i18next';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faPaperPlane, faTimes } from '@fortawesome/free-solid-svg-icons';
import './Modal.css';

const ChatModal = ({ orderId, recipientUsername, onClose, isAdminChat }) => {
  const [messages, setMessages] = useState([]);
  const [newMessage, setNewMessage] = useState('');
  const [loading, setLoading] = useState(true);
  const currentUser = useSelector((state) => state.username);
  const roles = useSelector((state) => state.roles); 
  const isAdmin = roles?.includes('ROLE_ADMIN');  
  const { t } = useTranslation();
  const messagesEndRef = useRef(null);
  const messagesContainerRef = useRef(null);
  const lastMessageIdRef = useRef(null);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  const fetchMessages = async () => {
    try {
      let response;
      if (isAdminChat) {
        response = await MessageService.getAdminUserDialogMessages(orderId, recipientUsername);
      } else {
        response = await MessageService.getDialogMessages(orderId, currentUser, recipientUsername);
      }
      
      if (response.data && Array.isArray(response.data)) {
        const newMessages = response.data;
        const lastMessage = newMessages[newMessages.length - 1];
        
        // Если это первая загрузка или есть новые сообщения
        if (!lastMessageIdRef.current || (lastMessage && lastMessage.id !== lastMessageIdRef.current)) {
          setMessages(newMessages);
          if (lastMessage) {
            lastMessageIdRef.current = lastMessage.id;
          }
          // Прокручиваем вниз только если пользователь уже был внизу
          const container = messagesContainerRef.current;
          if (container && container.scrollHeight - container.scrollTop - container.clientHeight < 100) {
            setTimeout(scrollToBottom, 100);
          }
        }
      }
    } catch (error) {
      console.error('Failed to load messages', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchMessages();
    const interval = setInterval(fetchMessages, 5000); // Увеличиваем интервал до 5 секунд
    return () => clearInterval(interval);
  }, [orderId, recipientUsername, isAdminChat]);

  const handleSendMessage = async () => {
    if (!newMessage.trim()) return;

    try {
      let recipient = recipientUsername;
      if (isAdminChat && !isAdmin) {
        recipient = 'admin';
      }
      await MessageService.sendMessage({
        orderId,
        recipientUsername: recipient,
        content: newMessage,
      });
      setNewMessage('');
      fetchMessages(); // Обновляем сообщения после отправки
    } catch (error) {
      console.error('Failed to send message', error);
    }
  };

  const getDisplayName = (username) => {
    if (username === 'admin' || roles?.includes('ROLE_ADMIN')) {
      return t('Administrator');
    }
    return username;
  };

  return (
    <div className="modal-overlay">
      <div className="modal-container chat-modal">
        <div className="modal-header">
          <h3 className="modal-title">{t('Chat')}</h3>
          <button className="modal-close" onClick={onClose}>
            <FontAwesomeIcon icon={faTimes} />
          </button>
        </div>
        <div className="modal-body chat-body">
          {loading ? (
            <div className="chat-loading">
              <div className="spinner"></div>
              <span>{t('Loading messages...')}</span>
            </div>
          ) : messages.length === 0 ? (
            <div className="chat-empty">
              {t('No messages yet. Start the conversation!')}
            </div>
          ) : (
            <ul className="chat-messages" ref={messagesContainerRef}>
              {messages.map((msg) => (
                <li 
                  key={msg.id} 
                  className={`chat-message ${msg.senderUsername === currentUser ? 'chat-message-sent' : 'chat-message-received'}`}
                >
                  <div className="chat-message-header">
                    <strong>{getDisplayName(msg.senderUsername)}</strong>
                    <span className="chat-message-time">
                      {new Date(msg.createdAt).toLocaleTimeString()}
                    </span>
                  </div>
                  <div className="chat-message-content">{msg.content}</div>
                </li>
              ))}
              <div ref={messagesEndRef} />
            </ul>
          )}
          <div className="chat-input-container">
            <textarea
              className="chat-input"
              value={newMessage}
              onChange={(e) => setNewMessage(e.target.value)}
              placeholder={t('Type your message...')}
              onKeyPress={(e) => e.key === 'Enter' && handleSendMessage()}
            />
            <button 
              className="chat-send-button"
              onClick={handleSendMessage}
              disabled={!newMessage.trim()}
            >
              <FontAwesomeIcon icon={faPaperPlane} />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ChatModal;