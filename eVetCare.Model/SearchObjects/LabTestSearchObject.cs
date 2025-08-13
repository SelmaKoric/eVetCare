namespace eVetCare.Model.SearchObjects
{
    public class LabTestSearchObject:BaseSearchObject
    {
        public string Name { get; set; } = null!;

        public string? Unit { get; set; }

        public string? ReferenceRange { get; set; }
    }
}
