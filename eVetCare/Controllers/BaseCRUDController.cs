using eVetCare.API.Controllers;
using eVetCare.Model.SearchObjects;
using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("[controller]")]
public class BaseCRUDController<TModel, TSearch, TInsert, TUpdate> : BaseController<TModel, TSearch>
    where TSearch : BaseSearchObject
    where TModel : class
{
    protected new ICRUDService<TModel, TSearch, TInsert, TUpdate> _service { get; set; }

    public BaseCRUDController(ICRUDService<TModel, TSearch, TInsert, TUpdate> service) : base(service)
    {
        _service = service;
    }

    [HttpPost]
    public virtual TModel Insert([FromBody] TInsert request) => _service.Insert(request);

    [HttpPut("{id:int}")]
    public virtual TModel Update(int id, [FromBody] TUpdate request) => _service.Update(id, request);

    [HttpDelete("{id:int}")]
    public virtual IActionResult SoftDelete(int id)
    {
        var ok = _service.SoftDelete(id);
        if (!ok) return NotFound();
        return NoContent();
    }

    [HttpPost("{id:int}/restore")]
    public virtual IActionResult Restore(int id)
    {
        var ok = _service.Restore(id);
        if (!ok) return NotFound();
        return NoContent();
    }

    [HttpPatch("{id:int}/status")]
    public virtual IActionResult SetActive(int id, [FromBody] SetActiveDto dto)
    {
        var ok = dto.IsActive ? _service.Restore(id) : _service.SoftDelete(id);
        if (!ok) return NotFound();
        return NoContent();
    }
}

public record SetActiveDto(bool IsActive);
