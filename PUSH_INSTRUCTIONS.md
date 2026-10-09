# Pushing this to github.com/roohisingh/ANNEE-skin-lesion

The archive contains a git repository with one commit already made.

    unzip ANNEE-skin-lesion.zip
    cd ANNEE-skin-lesion

    # confirm it is intact
    python -m pip install -r requirements.txt
    python -m pytest -q          # expect 79 passed
    python scripts/count_macs.py # expect Table 2, exactly

    # create the repository on GitHub, then
    git remote add origin https://github.com/roohisingh/ANNEE-skin-lesion.git
    git branch -M main
    git push -u origin main

Make the repository **public** before submitting: Section 3.12 of the
manuscript prints the bare URL, and a reviewer must be able to open it. If you
would rather keep it private during review, replace the URL in Section 3.12
with a reviewer-access link and change it back on acceptance.

Then work through RELEASE_CHECKLIST.md: the repository currently holds the
code, not the results, and Section 3.12 promises both.
