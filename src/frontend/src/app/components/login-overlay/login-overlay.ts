import { Component, output, signal } from '@angular/core';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { InputTextModule } from 'primeng/inputtext';
import { PasswordModule } from 'primeng/password';
import { SelectModule } from 'primeng/select';
import { ButtonModule } from 'primeng/button';

@Component({
  selector: 'ta-login-overlay',
  imports: [ReactiveFormsModule, InputTextModule, PasswordModule, SelectModule, ButtonModule],
  templateUrl: './login-overlay.html',
  styleUrl: './login-overlay.scss',
  host: { '(click)': '$event.stopPropagation()' },
})
export class LoginOverlayComponent {
  readonly exit = output<void>();

  protected readonly form = new FormGroup({
    username: new FormControl('', { nonNullable: true, validators: [Validators.required] }),
    password: new FormControl('', { nonNullable: true, validators: [Validators.required] }),
    operationMode: new FormControl('', { nonNullable: true }),
  });

  protected readonly loading = signal(false);
  protected readonly errorMsg = signal('');
  protected readonly activeField = signal<'username' | 'password'>('username');

  protected readonly numpadDigits = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];

  protected readonly operationModes = [
    { label: 'Normal', value: 'normal' },
    { label: 'Supervisor', value: 'supervisor' },
  ];

  protected onNumpadKey(key: string): void {
    const control = this.form.get(this.activeField());
    if (control) {
      control.setValue(control.value + key);
    }
  }

  protected onNumpadBackspace(): void {
    const control = this.form.get(this.activeField());
    if (control && control.value.length > 0) {
      control.setValue(control.value.slice(0, -1));
    }
  }

  protected onFieldFocus(field: 'username' | 'password'): void {
    this.activeField.set(field);
  }

  protected onSubmit(): void {
    if (this.form.invalid) return;

    this.loading.set(true);
    this.errorMsg.set('');

    const { username, password } = this.form.getRawValue();
    const ws = new WebSocket('ws://localhost:8080/ws/auth');

    ws.onopen = () => {
      ws.send(JSON.stringify({ type: 'auth', username, password }));
    };

    ws.onmessage = (event) => {
      ws.close();
      const response = JSON.parse(event.data);
      this.loading.set(false);

      if (response.success) {
        sessionStorage.setItem('ta_token', response.token);
      } else {
        this.errorMsg.set(response.message ?? 'Credenciales incorrectas');
      }
    };

    ws.onerror = () => {
      ws.close();
      this.loading.set(false);
      this.errorMsg.set('No se pudo conectar al servidor.');
    };
  }

  protected onExit(): void {
    this.exit.emit();
  }
}
