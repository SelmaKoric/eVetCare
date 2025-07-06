using System;
using eVetCare.Model;
using eVetCare.Model.SearchObjects;

namespace eVetCare.Services.Interfaces
{
    public interface IService<TModel, TSearch> where TSearch : BaseSearchObject
    {
        public GetPaged<TModel> GetPaged(TSearch search);
        public TModel GetById(int Id);
    }
}

