import { Component, computed, inject, signal, DestroyRef } from '@angular/core';

@Component({
  selector: 'ta-header-info',
  templateUrl: './header-info.html',
  styleUrl: './header-info.scss',
})
export class HeaderInfoComponent {
  private readonly destroyRef = inject(DestroyRef);

  protected readonly now = signal(new Date());

  protected readonly time = computed(() => {
    const d = this.now();
    const pad = (n: number) => String(n).padStart(2, '0');
    return `${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`;
  });

  protected readonly date = computed(() => {
    const d = this.now();
    return d.toLocaleDateString('en-US', {
      weekday: 'long',
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
    });
  });

  protected readonly supervisorName = signal('Giovanni Pierpaolo Detreti');
  protected readonly operatorName = signal('Clara Luciani Ross');
  protected readonly shiftNumber = signal('6 - Evening');
  protected readonly laneNumber = signal('1129A');
  protected readonly tollBooth = signal('1A');

  constructor() {
    const interval = setInterval(() => this.now.set(new Date()), 1000);
    this.destroyRef.onDestroy(() => clearInterval(interval));
  }
}
