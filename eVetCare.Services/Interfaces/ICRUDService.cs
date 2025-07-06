using System;
using eVetCare.Model.SearchObjects;

namespace eVetCare.Services.Interfaces
{
    public interface ICRUDService<TModel, TSearch, TInsert, TUpdate> : IService<TModel, TSearch> where TModel : class where TSearch : BaseSearchObject
    {
        TModel Insert(TInsert request);
        TModel Update(int Id, TUpdate request);
    }
}

