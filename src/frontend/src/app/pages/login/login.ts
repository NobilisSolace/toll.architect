import { Component, signal } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { PasswordModule } from 'primeng/password';
import { MessageModule } from 'primeng/message';
import { CardModule } from 'primeng/card';
import { ProgressSpinnerModule } from 'primeng/progressspinner';

@Component({
  selector: 'ta-login',
  standalone: true,
  imports: [
    ReactiveFormsModule,
    ButtonModule,
    InputTextModule,
    PasswordModule,
    MessageModule,
    CardModule,
    ProgressSpinnerModule
  ],
  templateUrl: './login.html',
  styleUrl: './login.scss'
})
export class LoginComponent {
  form: FormGroup;
  loading = signal(false);
  errorMsg = signal('');

  constructor(private fb: FormBuilder, private router: Router) {
    this.form = this.fb.group({
      username: ['', Validators.required],
      password: ['', Validators.required]
    });
  }

  onSubmit(): void {
    if (this.form.invalid) return;

    this.loading.set(true);
    this.errorMsg.set('');

    const { username, password } = this.form.value;
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
        this.router.navigate(['/lane']);
      } else {
        this.errorMsg.set(response.message ?? 'Credenciales incorrectas');
      }
    };

    ws.onerror = () => {
      ws.close();
      this.loading.set(false);
      this.errorMsg.set('No se pudo conectar al servidor. Intente nuevamente.');
    };
  }
}
