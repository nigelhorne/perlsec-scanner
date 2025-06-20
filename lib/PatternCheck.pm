package PatternCheck;
use Exporter 'import';
our @EXPORT_OK = qw(check_static_patterns);

# ENV:
# Directly accessing the `%ENV` hash throughout PatternCheck is considered “bad” because it scatters global state access all over your code, making it unpredictable and difficult to test or maintain. When your code reads from `%ENV` in multiple, uncoordinated places, you end up with hidden dependencies that can lead to side effects—especially when different parts of your program unexpectedly alter global variables. Instead, you should consolidate all environment variable accesses into a single, well-defined configuration layer or accessor function. For example, create a configuration module that reads, validates, and caches the required environment variables once at startup. Then pass this configuration (or its relevant parts) as arguments (dependency injection) to other functions or objects that need it. This approach not only improves testability but also enhances maintainability and security by isolating the mutable environment data within a controlled interface.

# Unsanitized user input:
# Accessing unsanitized user input—especially in a tool like PatternCheck—can introduce severe security risks such as injection vulnerabilities, unpredictable behavior, and difficulties in testing or maintaining your code. To address this concern, you should:
# 1. **Centralize Input Handling:** Instead of sprinkling direct accesses to external data (like user-supplied values) throughout your code, create a single module or set of functions responsible for reading, validating, and sanitizing all user inputs. This approach minimizes hidden dependencies and affords a consistent validation strategy across your application.
# 2. **Validate Against a Whitelist:** Rigorously define what constitutes acceptable input. Use regular expressions or dedicated validation libraries to ensure that the input strictly conforms to that expected format. Reject or flag any input that doesn’t match your whitelist criteria.
# 3. **Utilize Perl’s Taint Mode:** Run your scripts in taint mode (using the `-T` flag) so that any data coming from outside sources is automatically marked as tainted. You must explicitly “untaint” this data using stringent pattern matches before it can be used in critical operations.
# 4. **Escape or Sanitize When Necessary:** When the input must be incorporated into strings or passed to system calls, ensure dangerous characters are either removed or properly escaped. Leveraging existing libraries or writing dedicated sanitization routines can mitigate risks associated with escape sequences and special characters.
# 5. **Pass Sanitized Parameters Explicitly:** Instead of having functions or components directly access global sources (like `%ENV`), pass sanitized parameters explicitly through function arguments. This reduces coupling and improves both security and testability.

sub check_static_patterns
{
	my ($line, $file, $line_no, $ref) = @_;

	if($line =~ /
	   (eval\s+\$\w+|           # risky eval
	   system\(|              # shell execution
	   `[^`]*`|               # backticks
	   open\s+[^,]+,\s*['"]>| # file open for writing
	   \$ENV{|                # environment vars accessed directly
	   \b(param|input)\b      # unsanitized user input
	   )/x) {
		push @$ref, [$file, $line_no, "Insecure pattern: $line", 'PatternCheck', 'Medium'];
	}
}
1;
