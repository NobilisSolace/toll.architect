import { Component, signal } from '@angular/core';

type DeviceStatus = 'offline' | 'online' | 'warning';

interface Device {
  id: string;
  label: string;
  status: DeviceStatus;
}

interface DeviceGroup {
  category: string;
  devices: Device[];
}

@Component({
  selector: 'ta-dispositives-status',
  templateUrl: './dispositives-status.html',
  styleUrl: './dispositives-status.scss',
})
export class DispositivesStatusComponent {
  protected readonly groups = signal<DeviceGroup[]>([
    {
      category: 'PMV',
      devices: [
        { id: 'dms-1', label: 'DMS 1', status: 'offline' },
        { id: 'dms-2', label: 'DMS 2', status: 'offline' },
      ],
    },
    {
      category: 'Señales',
      devices: [
        { id: 'sem', label: 'SEM', status: 'offline' },
        { id: 'display', label: 'DISP', status: 'offline' },
      ],
    },
    {
      category: 'TCE Pre',
      devices: [
        { id: 'peana-pre', label: 'PEANA', status: 'offline' },
        { id: 'cortina-pre', label: 'CORT', status: 'offline' },
        { id: 'lidar-pre', label: 'LIDAR', status: 'offline' },
      ],
    },
    {
      category: 'TCE Post',
      devices: [
        { id: 'laser-post', label: 'LASER', status: 'offline' },
        { id: 'lazo-post', label: 'LAZO', status: 'offline' },
        { id: 'cam-post', label: 'CAM', status: 'offline' },
        { id: 'barrera', label: 'BARR', status: 'offline' },
      ],
    },
    {
      category: 'Cámaras',
      devices: [
        { id: 'cam-carril', label: 'CARRIL', status: 'offline' },
        { id: 'cam-cabina', label: 'CABINA', status: 'offline' },
        { id: 'anpr', label: 'ANPR', status: 'offline' },
        { id: 'cam-balizaje', label: 'BALIZ', status: 'offline' },
      ],
    },
    {
      category: 'RFID',
      devices: [
        { id: 'rfid-fijo', label: 'TAG', status: 'offline' },
      ],
    },
    {
      category: 'Operador',
      devices: [
        { id: 'impresora', label: 'IMP', status: 'offline' },
        { id: 'pedal', label: 'PED', status: 'offline' },
      ],
    },
  ]);
}
