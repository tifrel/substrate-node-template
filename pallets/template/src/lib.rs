// if feature "std" is not set, use `no_std`
#![cfg_attr(not(feature = "std"), no_std)]

// Re-export this pallet
pub use pallet::*;

#[frame_support::pallet]
pub mod pallet {
	use frame_support::{dispatch::DispatchResultWithPostInfo, pallet_prelude::*};
	use frame_system::pallet_prelude::*;
	use sp_std::vec::Vec;

	// our mixin to the runtime
	#[pallet::config]
	pub trait Config: frame_system::Config {
		// subtrait of the runtimes definition of an event
		type Event: From<Event<Self>> + IsType<<Self as frame_system::Config>::Event>;
	}

	// Either adding or removing proof, always associated with an account ID
	// and some proof data
	#[pallet::event]
	// Give a name to the compiled AccountId types, so it can be serialized,
	// can only be used after the `#[pallet::event]` attribute
	#[pallet::metadata(T::AccountId = "AccountId")]
	// autogenerate the deposit event with specified visibility
	#[pallet::generate_deposit(pub(super) fn deposit_event)]
	pub enum Event<T: Config> {
		/// A proof has been claimed. [who, proof]
		ClaimCreated(T::AccountId, Vec<u8>),
		/// A claim has been revoked. [who, proof]
		ClaimRevoked(T::AccountId, Vec<u8>),
	}


	#[pallet::error]
	pub enum Error<T> {
		/// Proof has been claimed by someone else already
		ProofAlreadyClaimed,
		/// Tried to revoke non-existent proof
		NoSuchProof,
		/// Tried to revoke a proof owned by someone else
		NotProofOwner,
	}

	#[pallet::pallet]
	#[pallet::generate_store(pub(super) trait Store)]
	pub struct Pallet<T>(_);

	#[pallet::storage]
	pub(super) type Proofs<T: Config> = StorageMap<_, Blake2_128Concat, Vec<u8>, (T::AccountId, T::BlockNumber), ValueQuery>;

	#[pallet::hooks]
	impl<T: Config> Hooks<BlockNumberFor<T>> for Pallet<T> {}

	#[pallet::call]
	impl<T: Config> Pallet<T> {
		#[pallet::weight(1_000)]
		pub fn create_claim(
			origin: OriginFor<T>,
			proof: Vec<u8>
		) -> DispatchResultWithPostInfo {
			// extrinsic needs to be signed, identify signer
			let sender = ensure_signed(origin)?;

			// proof must not exist yet
			ensure!(!Proofs::<T>::contains_key(&proof), Error::<T>::ProofAlreadyClaimed);

			// get current block number
			let current_block = <frame_system::Pallet<T>>::block_number();

			// store the proof
			Proofs::<T>::insert(&proof, (&sender, current_block));

			// emit event
			Self::deposit_event(Event::ClaimCreated(sender, proof));

			// return successfully
			Ok(().into())
		}

		#[pallet::weight(10_000)]
		pub fn revoke_claim(
			origin: OriginFor<T>,
			proof: Vec<u8>
		) -> DispatchResultWithPostInfo {
			// see above
			let sender = ensure_signed(origin)?;

			// proof must exist
			ensure!(Proofs::<T>::contains_key(&proof), Error::<T>::NoSuchProof);

			// verify that only the claim owner can delete it
			let (owner, _) = Proofs::<T>::get(&proof);
			ensure!(sender == owner, Error::<T>::NotProofOwner);

			// remove it
			Proofs::<T>::remove(&proof);

			// emit event
			Self::deposit_event(Event::ClaimRevoked(sender, proof));

			// return successfully
			Ok(().into())
		}
	}
}
