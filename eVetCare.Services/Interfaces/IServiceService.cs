using System;
using eVetCare.Model;
using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;

namespace eVetCare.Services.Interfaces
{
	public interface IServiceService : ICRUDService<Service, ServiceSearchObject, ServiceInsertRequest, ServiceUpdateRequest>
    {
		
	}
}

