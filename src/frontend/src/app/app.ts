import { Component, signal } from '@angular/core';
import { HeaderInfoComponent } from './components/header-info/header-info';
import { DispositivesStatusComponent } from './components/dispositives-status/dispositives-status';
import { LoginOverlayComponent } from './components/login-overlay/login-overlay';

@Component({
  selector: 'ta-root',
  imports: [HeaderInfoComponent, DispositivesStatusComponent, LoginOverlayComponent],
  templateUrl: './app.html',
  styleUrl: './app.scss',
})
export class App {
  protected readonly showLogin = signal(false);

  protected onWorkAreaClick(): void {
    if (!this.showLogin()) {
      this.showLogin.set(true);
    }
  }

  protected onLoginExit(): void {
    this.showLogin.set(false);
  }
}
