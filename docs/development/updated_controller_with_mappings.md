# Updated Controller Implementation with Activity Insight Mappings

Based on your mentor's comment, here's the updated controller with proper mappings:

## app/controllers/api/committees_controller.rb

```ruby
module Api
  class CommitteesController < ApplicationController
    # Skip CSRF token verification for API requests
    skip_before_action :verify_authenticity_token
    
    # Authentication filter
    before_action :authenticate_api_key
    
    # POST /api/committees/faculty_committees
    # Expected params: { access_id: "xyz123" }
    # Returns: JSON with all committee memberships for the faculty member
    #
    # Example request:
    #   curl -X POST http://localhost:3000/api/committees/faculty_committees \
    #     -H "Content-Type: application/json" \
    #     -H "Authorization: your-api-key" \
    #     -d '{"access_id": "abc123"}'
    #
    def faculty_committees
      access_id = params[:access_id]
      
      # Validate required parameter
      if access_id.blank?
        render json: { error: 'access_id is required' }, status: :bad_request
        return
      end
      
      # Find all committee memberships for this faculty member
      # Note: We search by access_id which is the PSU ID
      committee_memberships = CommitteeMember
        .includes(submission: [:author, :program, :degree, degree: :degree_type], committee_role: [])
        .where(access_id: access_id)
      
      # Format the response for Activity Insight
      response_data = {
        faculty_access_id: access_id,
        committees: format_committees_for_activity_insight(committee_memberships)
      }
      
      render json: response_data, status: :ok
    end
    
    private
    
    # Authenticate using API Key from environment variable
    # The API Key should be passed in the Authorization header
    def authenticate_api_key
      provided_key = request.headers['Authorization']
      expected_key = ENV['COMMITTEE_API_KEY']
      
      unless provided_key.present? && provided_key == expected_key
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    end
    
    # Format committee memberships for Activity Insight
    # Maps ETDA fields to Activity Insight's expected format
    def format_committees_for_activity_insight(committee_memberships)
      committee_memberships.map do |membership|
        submission = membership.submission
        
        # Skip if submission is missing (data integrity issue)
        next if submission.nil?
        
        # Build the committee data object with Activity Insight mappings
        {
          # Committee member info (for reference)
          committee_member_id: membership.id,
          faculty_name: membership.name,
          faculty_email: membership.email,
          faculty_access_id: membership.access_id,
          
          # Activity Insight Mappings
          type_of_work: map_type_of_work(submission),
          committee_role: map_committee_role(membership),
          major: submission.program&.name,
          date_started: format_semester_year(submission.semester, submission.year),
          date_completed: format_semester_year(submission.semester, submission.year),
          
          # Student information
          student_name: submission.author&.name || "Unknown",
          student_access_id: submission.author&.access_id,
          
          # Submission information (for reference/debugging)
          submission_id: submission.id,
          title: submission.title,
          degree_name: submission.degree&.name,
          degree_type_name: submission.degree&.degree_type&.name,
          program_name: submission.program&.name,
          semester: submission.semester,
          year: submission.year,
          
          # Important dates
          defended_at: submission.defended_at,
          final_submission_approved_at: submission.final_submission_approved_at,
          
          # Status information
          submission_status: submission.status,
          committee_member_status: membership.status,
          approved_at: membership.approved_at,
          
          # ETDA-specific fields (for debugging/reference)
          etda_committee_role_name: membership.committee_role&.name,
          etda_committee_role_code: membership.committee_role&.code
        }
      end.compact # Remove nil entries
    end
    
    # Map DegreeType.name to Activity Insight "Type of Work"
    # Based on mentor's mapping:
    # - PHD Dissertation -> Dissertation Committee
    # - Master's Thesis -> Master's Committee  
    # - Honors Thesis -> Undergraduate Honors thesis
    # - Millennium Scholars -> Undergraduate Honors thesis
    # - SSET Paper -> Master's Paper Committee
    def map_type_of_work(submission)
      degree_type_name = submission.degree&.degree_type&.name
      
      return nil if degree_type_name.blank?
      
      case degree_type_name.downcase
      when /phd|dissertation|doctoral|doctorate/
        "Dissertation Committee"
      when /master|ms|ma/
        if submission.program&.name&.match?(/sset/i)
          "Master's Paper Committee"
        else
          "Master's Committee"
        end
      when /honors/
        "Undergraduate Honors thesis"
      when /millennium/
        "Undergraduate Honors thesis"
      when /sset/
        "Master's Paper Committee"
      else
        degree_type_name # Return original if no mapping found
      end
    end
    
    # Map ETDA committee role to Activity Insight role using regex matching
    # Activity Insight roles (in preference order):
    # [Co-Chairperson, Chairperson, Co-Advisor, Advisor, Supervisor, Mentor, Member, Second Reader, Reader, Other]
    #
    # Strategy: Check each AI role in order, return first match
    def map_committee_role(membership)
      etda_role = membership.committee_role&.name
      
      return "Other" if etda_role.blank?
      
      # Convert to lowercase for case-insensitive matching
      role_lower = etda_role.downcase
      
      # Check in preference order (highest priority first)
      return "Co-Chairperson" if role_lower.match?(/co[-\s]?chair/i)
      return "Chairperson" if role_lower.match?(/chair/i)
      return "Co-Advisor" if role_lower.match?(/co[-\s]?advisor/i)
      return "Advisor" if role_lower.match?(/advisor/i)
      return "Supervisor" if role_lower.match?(/supervisor/i)
      return "Mentor" if role_lower.match?(/mentor/i)
      return "Second Reader" if role_lower.match?(/second\s+reader/i)
      return "Reader" if role_lower.match?(/reader/i)
      return "Member" if role_lower.match?(/member/i)
      
      # Default to Other if no match
      "Other"
    end
    
    # Format semester and year for Activity Insight
    # Returns format like "Fall 2024" or just "2024" if semester is missing
    def format_semester_year(semester, year)
      return nil if year.nil?
      
      if semester.present?
        "#{semester} #{year}"
      else
        year.to_s
      end
    end
  end
end
```

## Key Changes Based on Mentor's Guidance

### 1. Type of Work Mapping

```ruby
# ETDA DegreeType.name -> Activity Insight Type of Work
"PhD" -> "Dissertation Committee"
"Master's" -> "Master's Committee"
"Honors" -> "Undergraduate Honors thesis"
"Millennium Scholars" -> "Undergraduate Honors thesis"
"SSET" -> "Master's Paper Committee"
```

### 2. Committee Role Mapping with Regex

The function checks in **priority order** (as specified by mentor):

```ruby
Priority 1: Co-Chairperson  (matches: "Co-Chair", "Co Chair", etc.)
Priority 2: Chairperson      (matches: "Chair", "Committee Chair", etc.)
Priority 3: Co-Advisor       (matches: "Co-Advisor", "Co Advisor", etc.)
Priority 4: Advisor          (matches: "Advisor", "Thesis Advisor", etc.)
Priority 5: Supervisor
Priority 6: Mentor
Priority 7: Member           (matches: "Committee Member", "Member", etc.)
Priority 8: Second Reader
Priority 9: Reader
Priority 10: Other           (default if no match)
```

**Why priority order matters:**
- "Committee Co-Chair" matches both "Co-Chairperson" AND "Chairperson"
- We check Co-Chairperson first, so it returns that (more specific)
- This prevents "Committee Co-Chair" from being mapped to just "Chairperson"

### 3. Date Fields

```ruby
# Both date_started and date_completed use:
# Submission.semester + Submission.year
# Result: "Fall 2024", "Spring 2025", etc.
```

### 4. Major Field

```ruby
# Maps directly to Program.name
major: submission.program&.name
# Result: "Computer Science", "Biology", etc.
```

## Updated .includes() for Performance

Notice the updated `.includes()`:

```ruby
CommitteeMember
  .includes(
    submission: [
      :author, 
      :program, 
      :degree, 
      degree: :degree_type  # ← Need this for type_of_work mapping
    ], 
    committee_role: []
  )
  .where(access_id: access_id)
```

This preloads `degree_type` through `degree`, so we can access `submission.degree.degree_type.name` without extra queries.

## Example Response

```json
{
  "faculty_access_id": "jms123",
  "committees": [
    {
      "committee_member_id": 1,
      "faculty_name": "Dr. Jane Smith",
      "faculty_email": "jms123@psu.edu",
      "faculty_access_id": "jms123",
      
      // Activity Insight Mapped Fields
      "type_of_work": "Dissertation Committee",
      "committee_role": "Chairperson",
      "major": "Computer Science",
      "date_started": "Fall 2024",
      "date_completed": "Fall 2024",
      
      // Student info
      "student_name": "John Doe",
      "student_access_id": "jd456",
      
      // Reference data
      "submission_id": 100,
      "title": "AI in Healthcare Research",
      "degree_name": "Doctor of Philosophy",
      "degree_type_name": "PhD",
      "program_name": "Computer Science",
      
      // For debugging - original ETDA values
      "etda_committee_role_name": "Committee Chair/Co-Chair",
      "etda_committee_role_code": "CC"
    }
  ]
}
```

## Testing the Mappings

You can test the mapping logic in Rails console:

```ruby
# Test type_of_work mapping
submission = Submission.first
degree_type = submission.degree&.degree_type&.name
puts "Degree Type: #{degree_type}"

case degree_type.downcase
when /phd/
  puts "Maps to: Dissertation Committee"
when /master/
  puts "Maps to: Master's Committee"
end

# Test committee_role mapping
member = CommitteeMember.first
etda_role = member.committee_role&.name
puts "ETDA Role: #{etda_role}"

role_lower = etda_role.downcase
if role_lower.match?(/co[-\s]?chair/i)
  puts "Maps to: Co-Chairperson"
elsif role_lower.match?(/chair/i)
  puts "Maps to: Chairperson"
elsif role_lower.match?(/member/i)
  puts "Maps to: Member"
end
```

## Next Steps

1. Implement this updated controller
2. Test with real data from your database
3. Verify the mappings are correct for your specific ETDA roles
4. Adjust regex patterns if needed based on actual role names in your database

The regex patterns might need fine-tuning based on the actual role names in your ETDA database. You can check what roles exist with:

```ruby
CommitteeRole.pluck(:name).uniq
```

Then adjust the regex patterns in `map_committee_role` if needed.
