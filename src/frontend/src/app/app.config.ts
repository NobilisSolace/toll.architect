import { ApplicationConfig, provideBrowserGlobalErrorListeners } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { providePrimeNG } from 'primeng/config';
import { definePreset } from '@primeuix/themes';
import Aura from '@primeuix/themes/aura';

import { routes } from './app.routes';

const TollArchitect = definePreset(Aura, {
  semantic: {
    primary: {
      50: '#e6f6fe',
      100: '#cdeefe',
      200: '#9cdcfc',
      300: '#6acbfb',
      400: '#38b9fa',
      500: '#06a8f9',
      600: '#0586c7',
      700: '#046595',
      800: '#034363',
      900: '#012232',
      950: '#011823',
    },
    colorScheme: {
      dark: {
        surface: {
          0: '#ffffff',
          50: '#fafafa',
          100: '#e0e0e0',
          200: '#bdbdbd',
          300: '#9e9e9e',
          400: '#616161',
          500: '#424242',
          600: '#333333',
          700: '#2c2c2c',
          800: '#1e1e1e',
          900: '#1a1a1a',
          950: '#121212',
        },
      },
      light: {
        surface: {
          0: '#ffffff',
          50: '#fafafa',
          100: '#f5f5f5',
          200: '#eeeeee',
          300: '#e0e0e0',
          400: '#bdbdbd',
          500: '#9e9e9e',
          600: '#757575',
          700: '#616161',
          800: '#424242',
          900: '#212121',
          950: '#121212',
        },
      },
    },
  },
});

export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideRouter(routes),
    provideAnimationsAsync(),
    providePrimeNG({
      theme: {
        preset: TollArchitect,
        options: { darkModeSelector: '.dark-mode' },
      },
    }),
  ],
};
