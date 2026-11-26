<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class AssessmentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'assessed_value' => ['required', 'numeric', 'min:0'],
            'plafon_percentage' => ['nullable', 'numeric', 'min:0', 'max:100'],
            'approved_principal' => [
                'required',
                'numeric',
                'min:0',
                'lte:assessed_value',
            ],
            'service_fee' => ['required', 'numeric', 'min:0'],
            'tenor_days' => ['required', 'integer', 'min:1', 'max:365'],
            'start_date' => ['required', 'date'],
            'due_date' => ['required', 'date', 'after_or_equal:start_date'],
            'customer_note' => ['nullable', 'string', 'max:2000'],
            'internal_note' => ['nullable', 'string', 'max:2000'],
        ];
    }
}
