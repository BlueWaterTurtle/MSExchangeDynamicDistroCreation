#script I used to create a DDG for the global sales team. 
#add and remove departments as needed. To update the dynamic distro with new filter perameters, just replace "new" with 'set' in the first line, it'll replace the filter with whatever you departments or titles you add. 
New-DynamicDistributionGroup -name "distro name" -primarysmtpaddress "distro email address" -RecipientFilter {
    (RecipientType -eq 'UserMailbox') -and (
    (Department -eq 'Sales - Cloudbadging') -or
		(Department -eq 'Sales - Account Management - IDW') -or
		(Department -eq 'Sales - Account Management - ACS') -or
		(Department -eq 'Sales - Operations') -or
		(Department -eq 'Sales') -or
		(Department -eq 'Sales - Field') -or
		(Department -eq 'Sales - Distribution') -or
		(Department -eq 'Sales Support') -or		
    (Title -eq 'Chief Commercial Officer')
    )
}
