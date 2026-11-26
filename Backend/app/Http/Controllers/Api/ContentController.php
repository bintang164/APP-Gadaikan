<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\OutletResource;
use App\Http\Resources\PromotionResource;
use App\Models\Faq;
use App\Models\Outlet;
use App\Models\Promotion;
use App\Models\SimulationConfig;
use Illuminate\Http\JsonResponse;

class ContentController extends Controller
{
    public function outlets()
    {
        return OutletResource::collection(Outlet::orderBy('id')->get());
    }

    public function promotions()
    {
        return PromotionResource::collection(Promotion::orderByDesc('id')->get());
    }

    public function faqs(): JsonResponse
    {
        return response()->json([
            'data' => Faq::orderBy('id')->get()->map(fn (Faq $faq) => [
                'id' => $faq->id,
                'question' => $faq->question,
                'answer' => $faq->answer,
                'is_demo' => (bool) $faq->is_demo,
            ]),
        ]);
    }

    public function simulationConfig(): JsonResponse
    {
        $config = SimulationConfig::first();

        if (! $config) {
            return response()->json(['message' => 'Konfigurasi simulasi belum tersedia.'], 404);
        }

        return response()->json([
            'plafon_percentage_by_category' => $config->plafon_percentage_by_category,
            'fee_rate_per_period' => (float) $config->fee_rate_per_period,
            'period_days' => $config->period_days,
            'allowed_tenor_days' => $config->allowed_tenor_days,
            'min_estimated_value' => (float) $config->min_estimated_value,
            'max_estimated_value' => (float) $config->max_estimated_value,
            'disclaimer' => $config->disclaimer,
            'is_demo' => (bool) $config->is_demo,
        ]);
    }
}
