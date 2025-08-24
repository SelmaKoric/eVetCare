using eVetCare.Model.SearchObjects;
using eVetCare.Services.Interfaces;

public interface ICRUDService<TModel, TSearch, TInsert, TUpdate>
    : IService<TModel, TSearch>
    where TSearch : BaseSearchObject
{
    TModel Insert(TInsert request);
    TModel Update(int id, TUpdate request);
    bool SoftDelete(int id);
    bool Restore(int id);
}