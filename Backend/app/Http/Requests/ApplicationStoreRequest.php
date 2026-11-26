<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ApplicationStoreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'category' => ['required', 'exists:categories,code'],
            'item_title' => ['required', 'string', 'max:180'],
            'item_details' => ['required', 'array'],
            'item_details.*' => ['string', 'max:500'],
            'estimated_value' => ['nullable', 'numeric', 'min:0'],
            'preferred_tenor_days' => ['nullable', 'integer', 'min:1', 'max:365'],
            'documents' => ['sometimes', 'array'],
            'documents.*.id' => ['required', 'exists:pawn_documents,id'],
        ];
    }
}
