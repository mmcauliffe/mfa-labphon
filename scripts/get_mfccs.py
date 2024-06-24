import csv
from pathlib import Path
from kalpy.feat.cmvn import CmvnComputer
from kalpy.data import Segment
from kalpy.utterance import Utterance
from kalpy.gmm.data import AlignmentArchive
from _kalpy.gmm import gmm_compute_likes
from _kalpy.hmm import SplitToPhones
from montreal_forced_aligner.models import AcousticModel
from montreal_forced_aligner.helper import mfa_open
import pywrapfst

temp_dir = Path(r"D:\temp\MFA\labphon\alignment")
phones_path = Path(r"D:\temp\MFA\labphon\dictionary/phones/phones.txt")
root_dir = Path(__file__).parent.parent
audio_file = root_dir.joinpath("data", "mfa_kmg.wav")
mfcc_file = root_dir.joinpath("data", "mfa_kmg_mfccs.csv")
lda_file = root_dir.joinpath("data", "mfa_kmg_ldas.csv")
likes_file = root_dir.joinpath("data", "mfa_kmg_likes.csv")


if __name__ == '__main__':
    print(AcousticModel.get_pretrained_path('english_mfa'))
    acoustic_model = AcousticModel(AcousticModel.get_pretrained_path('english_mfa'))
    print(acoustic_model.meta)
    seg = Segment(audio_file)
    utterance = Utterance(seg, "montreal forced aligner")
    utterance.generate_mfccs(acoustic_model.mfcc_computer)
    cmvn_computer = CmvnComputer()
    cmvn = cmvn_computer.compute_cmvn_from_features([utterance.mfccs])
    utterance.apply_cmvn(cmvn)
    feats = utterance.generate_features(
        acoustic_model.mfcc_computer,
        acoustic_model.pitch_computer,
        lda_mat=acoustic_model.lda_mat,
    )
    begin = 0
    end = begin + 16
    mfccs = utterance.mfccs.numpy()[begin:end, :]
    print(utterance.mfccs.numpy().shape, mfccs.shape)
    with mfa_open(mfcc_file, 'w') as f:
        writer = csv.DictWriter(f, ["feature", "midpoint", "frame", "coefficient"])
        writer.writeheader()
        for i in range(mfccs.shape[0]):
            for j in range(mfccs.shape[1]):
                writer.writerow({"feature": j, "midpoint": (i*0.01), "frame":i, "coefficient":mfccs[i,j]})
    lda = feats.numpy()[begin:end, :]
    with mfa_open(lda_file, 'w') as f:
        writer = csv.DictWriter(f, ["feature", "midpoint", "frame", "coefficient"])
        writer.writeheader()
        for i in range(lda.shape[0]):
            for j in range(lda.shape[1]):
                writer.writerow({"feature": j, "midpoint": (i*0.01), "frame":i, "coefficient":lda[i,j]})

    ali_path = temp_dir.joinpath("ali_first_pass.1.2.ark")
    words_path = temp_dir.joinpath("words_first_pass.1.2.ark")
    likes_path = temp_dir.joinpath("likelihoods_first_pass.1.2.ark")
    alignment_archive = AlignmentArchive(
        ali_path, words_file_name=words_path, likelihood_file_name=likes_path
    )
    symbol_table = pywrapfst.SymbolTable.read_text(phones_path)
    with mfa_open(likes_file, 'w') as f:
        writer = csv.DictWriter(f, ["phone", "midpoint", "frame", "likelihood"])
        writer.writeheader()
        for alignment in alignment_archive:
            print(len(alignment.alignment))
            likelihoods = alignment.per_frame_likelihoods.numpy()
            a = alignment.alignment
            print(a)
            print(likelihoods)
            split = SplitToPhones(acoustic_model.transition_model, a)
            phone_start = 0.0
            like_index = begin
            for s in split:
                print(s)
                phone_id = acoustic_model.transition_model.TransitionIdToPhone(s[0])
                label = symbol_table.find(phone_id)
                print(label)
                hmm_ids = [acoustic_model.transition_model.TransitionIdToHmmState(x) for x in s]
                print(hmm_ids)
                print([acoustic_model.transition_model.IsSelfLoop(x) for x in s])
                for x in s:
                    print(like_index)
                    writer.writerow({"phone": label, "midpoint": (like_index)*0.01, "frame":like_index, "likelihood":likelihoods[like_index]})
                    like_index+=1
                    if like_index >= end:
                        break
                if like_index >= end:
                    break

    if False:
        utterance.generate_mfccs(acoustic_model.mfcc_computer)
        cmvn_computer = CmvnComputer()
        cmvn = cmvn_computer.compute_cmvn_from_features([utterance.mfccs])
        utterance.apply_cmvn(cmvn)
        feats = utterance.generate_features(
            acoustic_model.mfcc_computer,
            acoustic_model.pitch_computer,
            lda_mat=acoustic_model.lda_mat,
        )
        likes = gmm_compute_likes(acoustic_model.acoustic_model, feats).numpy()[:11, :]
        with mfa_open(likes_file, 'w') as f:
            writer = csv.DictWriter(f, ["pdf", "midpoint", "frame", "likelihood"])
            writer.writeheader()
            for j in range(likes.shape[1]):
                max_like = likes[:,j].max()
                if max_like < -40:
                    continue
                print(max_like)
                for i in range(likes.shape[0]):
                    writer.writerow({"pdf": j, "midpoint": (i)*0.01, "frame":i, "likelihood":likes[i,j]})
        print(likes.shape)
