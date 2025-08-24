using eVetCare.Model;
using eVetCare.Model.SearchObjects;
using eVetCare.Services.Database;
using eVetCare.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

public abstract class BaseService<TModel, TSearch, TDbEntity> : IService<TModel, TSearch>
    where TSearch : BaseSearchObject
    where TDbEntity : class
    where TModel : class
{
    public EVetCareContext _context { get; set; }
    public IMapper _mapper { get; set; }

    public BaseService(EVetCareContext context, IMapper mapper)
    {
        _context = context;
        _mapper = mapper;
    }

    public virtual TModel GetById(int id)
    {
        var query = _context.Set<TDbEntity>().AsQueryable();
        query = query.Where(e => EF.Property<bool>(e, "IsActive"));
        var entity = query.FirstOrDefault(e => EF.Property<int>(e, "Id") == id);
        return entity != null ? _mapper.Map<TModel>(entity) : null;
    }

    public virtual GetPaged<TModel> GetPaged(TSearch search)
    {
        var query = _context.Set<TDbEntity>().AsQueryable();

        if (search.OnlyInactive)
            query = query.Where(e => !EF.Property<bool>(e, "IsActive"));
        else if (!search.IncludeInactive)
            query = query.Where(e => EF.Property<bool>(e, "IsActive"));

        query = Filter(search, query);

        var count = query.Count();

        if (search.Page.HasValue && search.PageSize.HasValue)
            query = query.Skip((search.Page.Value - 1) * search.PageSize.Value).Take(search.PageSize.Value);

        var list = query.ToList();
        var mapped = _mapper.Map<List<TModel>>(list);

        return new GetPaged<TModel>
        {
            Count = count,
            Result = mapped,
            Page = search.Page ?? 1,
            PageSize = search.PageSize ?? 10
        };
    }

    public virtual IQueryable<TDbEntity> Filter(TSearch search, IQueryable<TDbEntity> query) => query;
}
