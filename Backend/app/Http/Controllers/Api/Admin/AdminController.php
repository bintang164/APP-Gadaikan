<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\PawnApplication;
use App\Models\PawnTransaction;
use Illuminate\Http\JsonResponse;

class AdminController extends Controller
{
    public function dashboard(): JsonResponse
    {
        return response()->json([
            'total' => PawnApplication::count(),
            'submitted' => PawnApplication::where('status', 'submitted')->count(),
            'under_review' => PawnApplication::where('status', 'under_review')->count(),
            'approved' => PawnApplication::where('status', 'approved')->count(),
            'rejected' => PawnApplication::where('status', 'rejected')->count(),
            'active_transactions' => PawnTransaction::where('status', 'active')->count(),
        ]);
    }
}
