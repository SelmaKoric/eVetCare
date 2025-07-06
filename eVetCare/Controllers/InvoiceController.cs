using System;
using eVetCare.Model;
using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;
using eVetCare.Services;
using eVetCare.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace eVetCare.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class InvoiceController : BaseCRUDController<Invoice, InvoiceSearchObject, InvoiceInsertRequest, object>
    {
        public InvoiceController(IInvoiceService service) : base(service)
        {
        }
    }
}

