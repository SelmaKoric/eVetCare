using eVetCare.Model.SearchObjects;
using eVetCare.Services.Database;
using MapsterMapper;

public abstract class BaseCRUDService<TModel, TSearch, TDbEntity, TInsert, TUpdate>
    : BaseService<TModel, TSearch, TDbEntity>
    where TModel : class
    where TSearch : BaseSearchObject
    where TDbEntity : class
{
    public BaseCRUDService(EVetCareContext context, IMapper mapper) : base(context, mapper) { }

    public virtual TModel Insert(TInsert request)
    {
        var entity = _mapper.Map<TDbEntity>(request);

        var entry = _context.Entry(entity);
        if (entry.Metadata.FindProperty("IsActive") != null)
            entry.Property("IsActive").CurrentValue = true;

        BeforeInsert(request, entity);

        _context.Add(entity);
        _context.SaveChanges();

        return _mapper.Map<TModel>(entity);
    }

    // MUST exist for Appointment/Invoice overrides
    protected virtual void BeforeInsert(TInsert request, TDbEntity entity) { }

    public virtual TModel Update(int id, TUpdate request)
    {
        var entity = _context.Set<TDbEntity>().Find(id);
        if (entity == null) return null;

        _mapper.Map(request, entity);

        // MUST exist for Pets BeforeUpdate override
        BeforeUpdate(request, entity);

        _context.SaveChanges();
        return _mapper.Map<TModel>(entity);
    }

    // MUST exist for Pets BeforeUpdate override
    protected virtual void BeforeUpdate(TUpdate request, TDbEntity entity) { }

    // MUST be virtual for PetsService SoftDelete override
    public virtual bool SoftDelete(int id)
    {
        var entity = _context.Set<TDbEntity>().Find(id);
        if (entity == null) return false;

        _context.Entry(entity).Property("IsActive").CurrentValue = false;
        _context.SaveChanges();
        return true;
    }

    public virtual bool Restore(int id)
    {
        var entity = _context.Set<TDbEntity>().Find(id);
        if (entity == null) return false;

        _context.Entry(entity).Property("IsActive").CurrentValue = true;
        _context.SaveChanges();
        return true;
    }
}
