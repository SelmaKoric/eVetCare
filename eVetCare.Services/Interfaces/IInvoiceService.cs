using System;
using eVetCare.Model;
using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;

namespace eVetCare.Services.Interfaces
{
	public interface IInvoiceService : ICRUDService<Invoice, InvoiceSearchObject, InvoiceInsertRequest, object>
    {
		
	}
}

