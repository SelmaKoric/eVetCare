namespace eVetCare.Services.Database;

public partial class MedicalRecord
{
    public int MedicalRecordId { get; set; }

    public int PetId { get; set; }

    public int AppointmentId { get; set; }

    public DateTime Date { get; set; }

    public string? Notes { get; set; }

    public string? AnalysisProvided { get; set; }

    public bool? IsDeleted { get; set; }

    public bool IsActive { get; set; }

    public virtual Appointment Appointment { get; set; } = null!;

    public virtual ICollection<Diagnosis> Diagnoses { get; set; } = new List<Diagnosis>();

    public virtual ICollection<LabResult> LabResults { get; set; } = new List<LabResult>();

    public virtual Pet Pet { get; set; } = null!;

    public virtual ICollection<Treatment> Treatments { get; set; } = new List<Treatment>();

    public virtual ICollection<Vaccination> Vaccinations { get; set; } = new List<Vaccination>();
}
