using System;
using eVetCare.Model;
using eVetCare.Model.Requests;
using eVetCare.Model.SearchObjects;

namespace eVetCare.Services.Interfaces
{
	public interface IDiagnosesService : ICRUDService<Diagnoses, DiagnosesSearchObject, DiagnosesInsertRequest, DiagnosesUpdateRequest>
    {
		
	}
}

