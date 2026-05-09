using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DAL.Data.Models.AIPlanning;
using DAL.Data.Models.Subscription;

namespace DAL.Data.Models.IdentityModels
{
    public class Manager
    {
        public int Id { get; set; }
        [Required]
        public string UserId { get; set; } = null!;
        public ApplicationUser User { get; set; } = null!;
        [Required, MaxLength(100)]
        public string CompanyName { get; set; } = null!;
        [Required,MaxLength(200)]
        public string BusinessType { get; set; }
        [MaxLength(200)]
        public string? BusinessDescription { get; set; }
        public int? SubscriptionId { get; set; }
        public Subscription.Subscription? Subscription { get; set; }
        public DateTime? SubscriptionEndsAt { get; set; }
        // CurrentEmployeeCount removed - use database count directly via EmployeeRepository
        public bool IsActive { get; set; } = true;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }

        // Navigation
        public ICollection<Employee> Employees { get; set; } = new List<Employee>();
        public ICollection<AnnualTarget> AnnualTargets { get; set; } = new List<AnnualTarget>();
    }
}
