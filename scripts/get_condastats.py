from condastats.cli import overall, pkg_platform, pkg_version, pkg_python, data_source
from pathlib import Path
root_dir = Path(__file__).parent.parent

counts = overall("montreal-forced-aligner", monthly=True)
counts.to_csv(str(root_dir.joinpath("data", "mfa_conda_counts.csv")))
print(counts)