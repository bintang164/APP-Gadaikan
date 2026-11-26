<?php

namespace App\Http\Controllers\Api;

use App\Enums\TransactionStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\DemoPaymentRequest;
use App\Http\Resources\TransactionResource;
use App\Models\Notification;
use App\Models\PawnTransaction;
use App\Models\Payment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TransactionController extends Controller
{
    public function index(Request $request)
    {
        $query = PawnTransaction::where('user_id', $request->user()->id)
            ->with(['application.category', 'payments']);

        if ($status = $request->query('status')) {
            $query->where('status', $status);
        }

        $transactions = $query->orderByDesc('created_at')
            ->paginate(min((int) $request->query('per_page', 10), 100));

        return TransactionResource::collection($transactions);
    }

    public function show(Request $request, int $id): TransactionResource
    {
        $transaction = PawnTransaction::where('user_id', $request->user()->id)
            ->with(['application.category', 'payments'])
            ->findOrFail($id);

        return new TransactionResource($transaction);
    }

    public function demoPayment(DemoPaymentRequest $request, int $id): TransactionResource
    {
        $user = $request->user();
        $transaction = PawnTransaction::where('user_id', $user->id)->findOrFail($id);

        $transaction = DB::transaction(function () use ($request, $transaction, $user): PawnTransaction {
            Payment::create([
                'pawn_transaction_id' => $transaction->id,
                'recorded_by' => $user->id,
                'amount' => $request->input('amount'),
                'method' => $request->input('method').' (Simulasi Demo)',
                'is_demo' => true,
                'status' => 'recorded',
                'note' => 'Catatan pembayaran demo; bukan transaksi uang sungguhan.',
            ]);

            $paid = (float) $transaction->paid_amount + (float) $request->input('amount');
            $total = (float) $transaction->principal_amount + (float) $transaction->fee_amount;
            $transaction->paid_amount = min($paid, $total);
            $transaction->status = $paid >= $total
                ? TransactionStatus::PaidOff->value
                : TransactionStatus::Active->value;
            $transaction->save();

            Notification::create([
                'user_id' => $user->id,
                'type' => 'demo_payment',
                'title' => 'Pembayaran demo tercatat',
                'body' => 'Catatan pembayaran simulasi berhasil disimpan. Tidak ada uang sungguhan yang dipindahkan.',
                'transaction_id' => $transaction->id,
            ]);

            return $transaction->load(['application.category', 'payments']);
        });

        return new TransactionResource($transaction);
    }
}
