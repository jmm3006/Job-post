import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'main.dart';

class CreateJobPostScreen extends StatefulWidget {
  const CreateJobPostScreen({super.key});

  @override
  State<CreateJobPostScreen> createState() => _CreateJobPostScreenState();
}

class LanguageEntry {
  String language;
  String level;
  LanguageEntry({this.language = 'English', this.level = 'Conversational'});
}

class _CreateJobPostScreenState extends State<CreateJobPostScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _jobTitleController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skillsController = TextEditingController();
  final _salaryMinController = TextEditingController();
  final _salaryMaxController = TextEditingController();

  // State variables
  String? _workFormat = 'Remote';
  String? _employmentType = 'Full-time';
  final List<String> _skills = ['java', 'python', 'flutter', 'other'];
  final List<LanguageEntry> _languages = [LanguageEntry()];
  String _salaryCurrency = 'USD';
  String _salaryFrequency = 'Per month';
  bool _isLoading = false;

  @override
  void dispose() {
    _jobTitleController.dispose();
    _companyNameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _skillsController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    super.dispose();
  }

  void _addSkill() {
    if (_skillsController.text.isNotEmpty && !_skills.contains(_skillsController.text.trim())) {
      setState(() {
        _skills.add(_skillsController.text.trim());
        _skillsController.clear();
      });
    }
  }

  void _addLanguage() {
    setState(() {
      _languages.add(LanguageEntry());
    });
  }

  Future<void> _submitJobPost() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from('jobs').insert({
        'user_id': userId,
        'job_title': _jobTitleController.text.trim(),
        'company_name': _companyNameController.text.trim(),
        'location': _locationController.text.trim(),
        'work_format': _workFormat,
        'employment_type': _employmentType,
        'job_description': _descriptionController.text.trim(),
        'required_skills': _skills,
        'languages': _languages.map((e) => {'language': e.language, 'level': e.level}).toList(),
        'salary_min': int.tryParse(_salaryMinController.text.trim()) ?? 0,
        'salary_max': int.tryParse(_salaryMaxController.text.trim()) ?? 0,
        'salary_currency': _salaryCurrency,
        'salary_frequency': _salaryFrequency,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job post created successfully!'), backgroundColor: Colors.green),
      );
      _resetForm();
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      if (e.statusCode == '429') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Too many requests. Please wait 1 minute before retrying.'), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Auth Error: ${e.message}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _jobTitleController.clear();
    _companyNameController.clear();
    _locationController.clear();
    _descriptionController.clear();
    _skillsController.clear();
    _salaryMinController.clear();
    _salaryMaxController.clear();
    setState(() {
      _skills.clear();
      _skills.addAll(['java', 'python', 'flutter', 'other']);
      _languages.clear();
      _languages.add(LanguageEntry());
      _workFormat = 'Remote';
      _employmentType = 'Full-time';
      _salaryCurrency = 'USD';
      _salaryFrequency = 'Per month';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Create Job Post', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
            const SizedBox(height: 4),
            Text('Step 1 of 3 - Basic Information', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[400])),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Job Title *'),
              TextFormField(
                controller: _jobTitleController,
                decoration: InputDecoration(
                  hintText: 'e.g. Senior Software Engineer',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: RequiredValidator(errorText: 'Job title is required'),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),

              _buildSectionHeader('Company Name *'),
              TextFormField(
                controller: _companyNameController,
                decoration: InputDecoration(
                  hintText: 'Your company name',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: RequiredValidator(errorText: 'Company name is required'),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),

              _buildSectionHeader('Location *'),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'City, State',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                validator: RequiredValidator(errorText: 'Location is required'),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),

              _buildSectionHeader('Work Format *'),
              _buildChoiceChipGroup(['Remote', 'Onsite', 'Hybrid'], _workFormat, (val) => setState(() => _workFormat = val)),
              const SizedBox(height: 20),

              _buildSectionHeader('Employment Type *'),
              _buildChoiceChipGroup(['Full-time', 'Part-time', 'Project', 'Shift'], _employmentType, (val) => setState(() => _employmentType = val)),
              const SizedBox(height: 20),

              _buildSectionHeader('Job Description *'),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Describe the role, responsibilities, and requirements...',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                maxLines: 5,
                validator: RequiredValidator(errorText: 'Description is required'),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),

              _buildSectionHeader('Required Skills'),
              TextFormField(
                controller: _skillsController,
                decoration: InputDecoration(
                  hintText: 'Add skills (e.g., custom skills)',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add, color: Color(0xFFB3C26A)),
                    onPressed: _addSkill,
                  ),
                ),
                onFieldSubmitted: (value) => _addSkill(),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _skills.map((skill) => Chip(
                  label: Text(skill, style: const TextStyle(color: Colors.white)),
                  backgroundColor: const Color(0xFF3A3A3C),
                  deleteIcon: const Icon(Icons.close, size: 16, color: Colors.grey),
                  onDeleted: () => setState(() => _skills.remove(skill)),
                )).toList(),
              ),
              const SizedBox(height: 20),

              _buildSectionHeader('Languages'),
              ..._buildLanguageFields(),
              TextButton.icon(
                onPressed: _addLanguage,
                icon: const Icon(Icons.add, color: Color(0xFFB3C26A)),
                label: const Text('Add language', style: TextStyle(color: Color(0xFFB3C26A))),
                style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 20),

              _buildSectionHeader('Salary Range'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _salaryMinController,
                            decoration: InputDecoration(
                              hintText: 'Min',
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _salaryMaxController,
                            decoration: InputDecoration(
                              hintText: 'Max',
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _salaryCurrency,
                          dropdownColor: Theme.of(context).colorScheme.surface,
                          style: const TextStyle(color: Colors.white),
                          underline: const SizedBox(),
                          items: ['USD', 'UZS', 'EUR'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _salaryCurrency = val!),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Radio<String>(
                          value: 'Per month',
                          groupValue: _salaryFrequency,
                          onChanged: (val) => setState(() => _salaryFrequency = val!),
                          activeColor: const Color(0xFFB3C26A),
                        ),
                        const Text('Per month', style: TextStyle(color: Colors.white)),
                        const SizedBox(width: 16),
                        Radio<String>(
                          value: 'Per hour',
                          groupValue: _salaryFrequency,
                          onChanged: (val) => setState(() => _salaryFrequency = val!),
                          activeColor: const Color(0xFFB3C26A),
                        ),
                        const Text('Per hour', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF3A3A3C)),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Save as Draft'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitJobPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB3C26A),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : const Text('Next'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
    );
  }

  Widget _buildChoiceChipGroup(List<String> items, String? selectedValue, ValueChanged<String> onChanged) {
    return Wrap(
      spacing: 8.0,
      children: items.map((item) => ChoiceChip(
        label: Text(item, style: TextStyle(color: selectedValue == item ? Colors.black : Colors.white)),
        selected: selectedValue == item,
        onSelected: (selected) {
          if (selected) onChanged(item);
        },
        selectedColor: const Color(0xFFB3C26A),
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      )).toList(),
    );
  }

  List<Widget> _buildLanguageFields() {
    return List.generate(_languages.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: _languages[index].language,
                decoration: InputDecoration(
                  hintText: 'Language',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                onChanged: (val) => _languages[index].language = val,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _languages[index].level,
                decoration: InputDecoration(
                  hintText: 'Level',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                dropdownColor: Theme.of(context).colorScheme.surface,
                style: const TextStyle(color: Colors.white),
                items: ['Conversational', 'Fluent', 'Native'].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (val) => setState(() => _languages[index].level = val!),
              ),
            ),
            if (_languages.length > 1)
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                onPressed: () => setState(() => _languages.removeAt(index)),
              ),
          ],
        ),
      );
    });
  }
}