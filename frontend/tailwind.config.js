import forms from '@tailwindcss/forms';
import typography from '@tailwindcss/typography';

export default {
  darkMode: 'class',
  content: ['./src/**/*.{html,js,svelte,ts}'],
  theme: {
    extend: {
      colors: {
        ink: '#0f0f0f',
        surface: '#1a1a1a',
        panel: '#232323',
        primary: '#6366f1',
        text: '#e5e5e5'
      }
    }
  },
  plugins: [forms, typography]
};
