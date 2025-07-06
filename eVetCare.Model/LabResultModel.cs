using System;
namespace eVetCare.Model
{
    public class LabResult
    {
        public int LabResultId { get; set; }

        public int LabTestId { get; set; }

        public string TestName { get; set; } = null!; 

        public string? ResultValue { get; set; }

        public string? Unit { get; set; }

        public string? ReferenceRange { get; set; }
    }
}

