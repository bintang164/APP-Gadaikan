<?php

namespace App\Enums;

enum TransactionStatus: string
{
    case Active = 'active';
    case PaymentPending = 'payment_pending';
    case PaidOff = 'paid_off';
    case Overdue = 'overdue';
    case Closed = 'closed';

    public function label(): string
    {
        return match ($this) {
            self::Active => 'Aktif',
            self::PaymentPending => 'Menunggu Konfirmasi',
            self::PaidOff => 'Lunas',
            self::Overdue => 'Jatuh Tempo',
            self::Closed => 'Ditutup',
        };
    }
}
