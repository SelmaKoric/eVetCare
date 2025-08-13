namespace eVetCare.Model.Requests
{
    public class LabTestUpsertRequest
    {
        public string Name { get; set; } = null!;

        public string? Unit { get; set; }

        public string? ReferenceRange { get; set; }
    }
}
