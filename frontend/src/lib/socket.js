import { Socket } from 'phoenix';

const API_URL = (import.meta.env.VITE_API_URL || 'https://learnflow-api-1eef.onrender.com').replace(/\/+$/, '');
const WS_URL = import.meta.env.VITE_WS_URL || `${API_URL.replace(/^http/, 'ws')}/socket`;

function sessionToken() {
  return document.cookie.split('; ').find((row) => row.startsWith('session_token='))?.split('=')[1] || '';
}

function connect() {
  const socket = new Socket(WS_URL, { params: { session_token: sessionToken() } });
  socket.connect();
  return socket;
}

function connectWithToken(socketToken) {
  const socket = new Socket(WS_URL, { params: { socket_token: socketToken } });
  socket.connect();
  return socket;
}

export function connectFeed(onNewVideo, onLike = () => {}) {
  const socket = connect();
  const channel = socket.channel('feed:lobby', {});
  channel.join();
  channel.on('new_video', (payload) => onNewVideo(payload.video));
  channel.on('like_updated', onLike);
  return () => socket.disconnect();
}

export function connectVideo(videoId, onComment, onLike) {
  const socket = connect();
  const channel = socket.channel(`video:${videoId}`, {});
  channel.join();
  channel.on('new_comment', (payload) => onComment(payload.comment));
  channel.on('like_updated', onLike);
  return () => socket.disconnect();
}

export function connectNotifications(userId, socketToken, onNotification) {
  if (!userId || !socketToken) return () => {};
  const socket = connectWithToken(socketToken);
  const channel = socket.channel(`notifications:${userId}`, {});
  channel.join();
  channel.on('new_notification', (payload) => onNotification(payload.notification));
  return () => socket.disconnect();
}

export function connectConversation(conversationId, handlers = {}, socketToken = '') {
  if (!conversationId) return { send: () => {}, read: () => {}, typing: () => {}, disconnect: () => {} };
  const socket = socketToken ? connectWithToken(socketToken) : connect();
  const channel = socket.channel(`conversation:${conversationId}`, {});
  channel.join().receive('ok', (payload) => handlers.onJoin?.(payload));
  channel.on('new_message', (payload) => handlers.onMessage?.(payload.message));
  channel.on('typing', (payload) => handlers.onTyping?.(payload));
  channel.on('read', (payload) => handlers.onRead?.(payload));
  channel.on('presence', (payload) => handlers.onPresence?.(payload));

  return {
    send: (payload) => channel.push('new_message', payload),
    read: () => channel.push('read', {}),
    typing: (is_typing = true) => channel.push('typing', { is_typing }),
    disconnect: () => socket.disconnect()
  };
}
