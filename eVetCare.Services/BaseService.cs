using eVetCare.Model;
using eVetCare.Model.SearchObjects;
using eVetCare.Services.Database;
using eVetCare.Services.Interfaces;
using MapsterMapper;

namespace eVetCare.Services
{
    public abstract class BaseService<TModel, TSearch, TDbEntity> : IService<TModel, TSearch> where TSearch : BaseSearchObject where TDbEntity : class where TModel : class
    {
        public EVetCareContext _context { get; set; }
        public IMapper _mapper { get; set; }

        public BaseService(EVetCareContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public virtual TModel GetById(int Id)
        {
            var entity = _context.Set<TDbEntity>().Find(Id);

            if (entity != null)
            {
                return _mapper.Map<TModel>(entity);
            }
            else
            {
                return null;
            }
        }

        public virtual GetPaged<TModel> GetPaged(TSearch search)
        {
            var query = _context.Set<TDbEntity>().AsQueryable();

            query = Filter(search, query);

            int count = query.Count();

            if (search.Page.HasValue == true && search.PageSize.HasValue == true)
            {
                query = query.Skip((search.Page.Value - 1) * search.PageSize.Value).Take(search.PageSize.Value);
            }

           
            var list = query.ToList();
            var mappedResults = _mapper.Map<List<TModel>>(list);
            GetPaged<TModel> pagedResult = new GetPaged<TModel>();
            pagedResult.Count = count; 
            pagedResult.Result = mappedResults;
            pagedResult.Page = search.Page ?? 1; 
            pagedResult.PageSize = search.PageSize ?? 10;

            return pagedResult;
        }

        public virtual IQueryable<TDbEntity> Filter(TSearch search, IQueryable<TDbEntity> query)
        {
            return query;
        }
    }
}

