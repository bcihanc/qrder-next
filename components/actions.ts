'use server';

export async function handleSubmit(formData: FormData) {
  console.log('Submitted username:', formData.get('username'));
}
