using eVetCare.Model.SearchObjects;
using eVetCare.Services;
using eVetCare.Services.Database;
using MapsterMapper;

public abstract class BaseCRUDService<TModel, TSearch, TDbEntity, TInsert, TUpdate> : BaseService<TModel, TSearch, TDbEntity> where TModel : class where TSearch : BaseSearchObject where TDbEntity : class
{
    public BaseCRUDService(EVetCareContext context, IMapper mapper)
        : base(context, mapper)
    {
    }

    public virtual TModel Insert(TInsert request)
    {
        TDbEntity entity = _mapper.Map<TDbEntity>(request);

        BeforeInsert(request, entity);

        _context.Add(entity);
        _context.SaveChanges();

        return _mapper.Map<TModel>(entity);
    }

    public virtual void BeforeInsert(TInsert request, TDbEntity entity)
    {

    }

    public virtual TModel Update(int id, TUpdate request)
    {
        var entity = _context.Set<TDbEntity>().Find(id);

        _mapper.Map(request, entity);

        BeforeUpdate(request, entity);

        _context.SaveChanges();
        
        return _mapper.Map<TModel>(entity);
    }

    public virtual void BeforeUpdate(TUpdate request, TDbEntity entity)
    {

    }
}
