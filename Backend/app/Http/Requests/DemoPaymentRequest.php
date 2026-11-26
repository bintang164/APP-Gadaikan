<?php

namespace App\Http\Requests;

use App\Models\PawnTransaction;
use Illuminate\Foundation\Http\FormRequest;

class DemoPaymentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'amount' => ['required', 'numeric', 'min:1'],
            'method' => ['required', 'string', 'max:120'],
            'is_demo' => ['sometimes', 'boolean'],
        ];
    }

    public function withValidator($validator): void
    {
        $validator->after(function ($validator): void {
            $transaction = PawnTransaction::find($this->route('transaction'));
            if ($transaction && (float) $this->input('amount') > $transaction->remainingAmount()) {
                $validator->errors()->add('amount', 'Nominal melebihi sisa kewajiban.');
            }
        });
    }
}
