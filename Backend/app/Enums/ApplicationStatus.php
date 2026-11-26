<?php

namespace App\Enums;

enum ApplicationStatus: string
{
    case Draft = 'draft';
    case Submitted = 'submitted';
    case UnderReview = 'under_review';
    case RevisionRequired = 'revision_required';
    case Approved = 'approved';
    case Rejected = 'rejected';
    case OfferAccepted = 'offer_accepted';
    case OfferDeclined = 'offer_declined';
    case Cancelled = 'cancelled';

    public function label(): string
    {
        return match ($this) {
            self::Draft => 'Draf',
            self::Submitted => 'Dikirim',
            self::UnderReview => 'Sedang Ditinjau',
            self::RevisionRequired => 'Perlu Perbaikan',
            self::Approved => 'Disetujui',
            self::Rejected => 'Ditolak',
            self::OfferAccepted => 'Penawaran Diterima',
            self::OfferDeclined => 'Penawaran Ditolak',
            self::Cancelled => 'Dibatalkan',
        };
    }
}
