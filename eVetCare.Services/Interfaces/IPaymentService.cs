using System;
using eVetCare.Model;
using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;

namespace eVetCare.Services.Interfaces
{
	public interface IPaymentService : ICRUDService<Payment, PaymentSearchObject, PaymentInsertRequest, object>
    {
        Task<string> CreatePaymentIntentAsync(int invoiceId);
    }
}

