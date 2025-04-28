import React, { useState, useEffect } from 'react';
import MessageService from '../Services/MessageService';
import { useSelector } from 'react-redux';

const ChatModal = ({ orderId, recipientUsername, onClose, isAdminChat }) => {
  const [messages, setMessages] = useState([]);
  const [newMessage, setNewMessage] = useState('');
  const currentUser = useSelector((state) => state.username);
  const roles = useSelector((state) => state.roles); 
  const isAdmin = roles?.includes('ROLE_ADMIN');  

  const fetchMessages = async () => {
    try {
      let response;
      if (isAdminChat) {
        // user — username пользователя!
        response = await MessageService.getAdminUserDialogMessages(orderId, recipientUsername);
      } else {
        response = await MessageService.getDialogMessages(orderId, currentUser, recipientUsername);
      }
      setMessages(response.data);
    } catch (error) {
      console.error('Failed to load messages', error);
    }
  };

  useEffect(() => {
    fetchMessages();
    const interval = setInterval(fetchMessages, 3000);
    return () => clearInterval(interval);
  }, [orderId, recipientUsername, isAdminChat]);

  const handleSendMessage = async () => {
    try {
      let recipient = recipientUsername;
      // Если пользователь пишет админу, recipientUsername === order.clientUsername, а надо — username админа
      if (isAdminChat && !isAdmin) {
        recipient = 'admin'; // или username любого админа, если есть
      }
      await MessageService.sendMessage({
        orderId,
        recipientUsername: recipient,
        content: newMessage,
      });
      setNewMessage('');
      fetchMessages();
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