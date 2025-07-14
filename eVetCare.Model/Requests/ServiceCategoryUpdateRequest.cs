namespace eVetCare.Model.Requests
{
    public class ServiceCategoryUpdateRequest
    {
        public string Name { get; set; } = null!;

        public bool? IsDeleted { get; set; }
    }
}
