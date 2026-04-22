use aiken/crypto/bls12_381/scalar
use zk_password/groth16.{Proof, VerificationKey, groth16_verify}

// Compressed verification key produced by circuit/compress_vk.js from the
// snarkjs verification_key.json. G1 = 48 bytes, G2 = 96 bytes.
fn test_vk() -> VerificationKey {
  VerificationKey {
    alpha: #"b0bb9ca659044688e0c6f528ba33801499ff302f86990e2fc46d39b7e300d01a742ec7bb3b9be32d5be1e1a6701457c4",
    beta: #"a283eaf1a7e2f5704293a16837a376392bfcbdeb745497454c4ae471c0157cfd6b651dbfca6c21230574e525149612c30d986d4f7ff919917ed3f782bac99bcc8ad37301b2c719eeb2d6713b93b0973b3f8c25fe020114c349ed43775fb810fb",
    gamma: #"93e02b6052719f607dacd3a088274f65596bd0d09920b61ab5da61bbdc7f5049334cf11213945d57e5ac7d055d042b7e024aa2b2f08f0a91260805272dc51051c6e47ad4fa403b02b4510b647ae3d1770bac0326a805bbefd48056c8c121bdb8",
    delta: #"987a4b1e9cbde7c6060fe790416828de4c3bf00d8b951ac012d476323a26f847f9e5306b0fbc88b2e43ee6aabea711fd1689b221d01ba8b9e80ab7c4304d241b652135b72e774d4ef7f223e81571199c817893903c0c1b6c991e899845a63114",
    ic: [
      #"8abfa7dfaa41e4a53744e0f46fcfe34e90dd5711714f718fce8f24b94e18572573c9d4a0d6d940500d41042e0607b3e2",
      #"9487208c535a8771711a4ee9e58e07311fe5996ffdd8aeff73045697578ebc191a4618dcccff8079e45a9a3ca77c5b08",
    ],
  }
}

// Compressed proof produced by snarkjs groth16 prove for pwd = 123456.
fn test_proof() -> Proof {
  Proof {
    pi_a: #"b15f6da17265cbb596036075e87ddfe62d210a92c65cb30ac65375659ef26511c50b55b989abc6da22f05495fca74380",
    pi_b: #"ac6f06b66982fc793de1a1d393b66f80f967cf4f984bc18ac9e034a618d732f5a9dd9c632da14178b54584a682f8070808437cb5f80c0559f9cddf71f7edbddb4853249ba637ec3a59950eff969e99a2d4574a6f229a753cdb2d5674fcf060cf",
    pi_c: #"8d6da5b26036b096441e48b6c490f56c4a4f9148a881b0e50c556626a4cef37d672c0e8d7c74fc0b2214e0bf63f36f8a",
  }
}

// Public input: Poseidon(123456) over BLS12-381, taken from snarkjs public.json.
// This is the credential_hash stored in the datum.
const credential_hash: Int =
  9415434746508747181228645764267412889835803815708024285868314342086739058356

// Groth16 verification passes for the correct proof and matching credential hash.
test groth16_verify_valid_proof() {
  expect Some(hash_scalar) = scalar.new(credential_hash)
  groth16_verify(test_vk(), test_proof(), [hash_scalar])
}

// Verification must fail when the credential hash is wrong (wrong password).
test groth16_verify_wrong_hash() fail {
  let wrong_hash = credential_hash + 1
  expect Some(hash_scalar) = scalar.new(wrong_hash)
  groth16_verify(test_vk(), test_proof(), [hash_scalar])
}
