using System;
namespace eVetCare.Model
{
    public class ServiceRating
    {
        public int OwnerId { get; set; }     
        public int ServiceId { get; set; }   
        public float Label { get; set; } = 1;
    }
}

