using System;
using System.Collections.Generic;
using System.Text;

namespace eVetCare.Model
{
    public class LabTestModel
    {
        public int LabTestId { get; set; }

        public string Name { get; set; } = null!;

        public string? Unit { get; set; }

        public string? ReferenceRange { get; set; }
    }
}
