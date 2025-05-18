// src/services/notificationBus.js
import mitt from 'mitt';

export const notificationBus = mitt();

// Helper to simplify calling toast with type & payload:
export function notify({ type = 'default', title, message, options = {} }) {
  // you can tailor this to your preference
  notificationBus.emit('notify', { type, render: () => (
    <div>
      {title && <h4 style={{ margin: 0 }}>{title}</h4>}
      <p style={{ margin: 0 }}>{message}</p>
    </div>
  ), options });
}
