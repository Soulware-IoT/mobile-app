/// Traffic-light severity the edge computes for each reading against the
/// device's safety thresholds. Mirrors the backend `SafetySeverity` enum.
enum ReadingSeverity { safe, warning, critical }

ReadingSeverity readingSeverityFromString(String? value) =>
    switch (value?.toLowerCase()) {
      'warning' => ReadingSeverity.warning,
      'critical' => ReadingSeverity.critical,
      _ => ReadingSeverity.safe,
    };
