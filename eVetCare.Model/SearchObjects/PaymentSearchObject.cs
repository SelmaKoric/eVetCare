using System;
namespace eVetCare.Model.SearchObjects
{
	public class PaymentSearchObject : BaseSearchObject
	{
        public int? MethodId { get; set; }

        public DateTime? PaymentDate { get; set; }
    }
}

